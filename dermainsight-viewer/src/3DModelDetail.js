import * as THREE from 'three';
import { GLTFLoader } from 'three/examples/jsm/loaders/GLTFLoader.js';
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js';

let renderer = null;
let container = null;
let scene = null;
let camera = null;
let controls = null;
let needsRender = false;

window.showModel = function (regionName, base64Glb, base64Png) {
  container = document.getElementById("3dModelArea");

  if (!container) {
    console.error("❌ '3dModelArea' div bulunamadı!");
    return;
  }

  if (container.offsetWidth < 10 || container.offsetHeight < 10) {
    console.warn("⏳ container henüz hazır değil, resizeObserver başlatılıyor...");
    const observer = new ResizeObserver(entries => {
      const entry = entries[0];
      if (entry.contentRect.width > 10 && entry.contentRect.height > 10) {
        observer.disconnect();
        console.log("✅ container boyutu hazır:", entry.contentRect.width, entry.contentRect.height);
        renderScene(regionName, base64Glb, base64Png);
      }
    });
    observer.observe(container);
  } else {
    renderScene(regionName, base64Glb, base64Png);
  }
};

function renderScene(regionName, base64Glb, base64Png) {
  if (!container) return;

  if (renderer) {
    renderer.dispose();
    while (container.firstChild) container.removeChild(container.firstChild);
  }

  scene = new THREE.Scene();
  scene.background = new THREE.Color(0x1E1E1E);

  camera = new THREE.PerspectiveCamera(
    60,
    container.clientWidth / container.clientHeight,
    0.01,
    1000
  );

  renderer = new THREE.WebGLRenderer({ antialias: true, alpha: false });
  renderer.setClearColor(0x1E1E1E);
  renderer.setSize(container.clientWidth, container.clientHeight);
  renderer.outputEncoding = THREE.sRGBEncoding;
  container.appendChild(renderer.domElement);

  const light1 = new THREE.HemisphereLight(0xffffff, 0x444444, 1.2);
  const light2 = new THREE.DirectionalLight(0xffffff, 1.5);
  light2.position.set(2, 2, 2);
  scene.add(light1, light2);

  controls = new OrbitControls(camera, renderer.domElement);
  controls.enableDamping = true;

  const loader = new GLTFLoader();
  const arrayBuffer = base64ToArrayBuffer(base64Glb);

  loader.parse(arrayBuffer, '', (gltf) => {
    const model = gltf.scene;
    scene.add(model);

    const box = new THREE.Box3().setFromObject(model);
    const center = box.getCenter(new THREE.Vector3());

    camera.position.set(0, 0, 2);
    camera.lookAt(center);
    controls.target.copy(center);

    model.traverse(child => {
      if (child.isMesh) {
        console.log(`🧩 Mesh bulundu: ${child.name} | Material: ${child.material?.name}`);
      }
    });

    const img = new Image();
    img.src = base64Png.startsWith("data:image") ? base64Png : `data:image/png;base64,${base64Png}`;
    img.onload = () => {
      const canvas = document.createElement("canvas");
      canvas.width = img.width;
      canvas.height = img.height;
      const ctx = canvas.getContext("2d");

      ctx.fillStyle = "#cba98e";
      ctx.fillRect(0, 0, canvas.width, canvas.height);
      ctx.globalCompositeOperation = "multiply";
      ctx.drawImage(img, 0, 0);
      ctx.globalCompositeOperation = "destination-in";
      ctx.drawImage(img, 0, 0);

      const texture = new THREE.Texture(canvas);
      texture.needsUpdate = true;
      texture.encoding = THREE.sRGBEncoding;

      const overlayMaterial = new THREE.MeshStandardMaterial({
        map: texture,
        transparent: true,
        alphaTest: 0.05,
        depthWrite: true,
        depthTest: true,
        side: THREE.DoubleSide
      });

      const targetMatName = `Mat_${regionName}`;
      let matched = false;

      model.traverse(child => {
        if (child.isMesh && child.material?.name === targetMatName) {
          const overlay = child.clone();
          overlay.material = overlayMaterial;
          overlay.renderOrder = 999;
          overlay.position.copy(child.position);
          overlay.rotation.copy(child.rotation);
          overlay.scale.copy(child.scale);
          scene.add(overlay);
          matched = true;
        }
      });

      if (!matched) {
        console.warn(`⚠️ Material eşleşmesi bulunamadı: ${targetMatName}`);
      }

      needsRender = true;
    };
  }, undefined, (error) => {
    console.error("❌ GLB yükleme hatası:", error);
  });

  controls.addEventListener('change', () => {
    needsRender = true;
  });

  animate(); // ✅ Başlat ama sürekli değil, gerektiğinde çiz
}

function animate() {
  requestAnimationFrame(animate);
  if (needsRender) {
    controls.update();
    renderer.render(scene, camera);
    needsRender = false;
  }
}

function base64ToArrayBuffer(base64) {
  try {
    const binary = window.atob(base64);
    const len = binary.length;
    const bytes = new Uint8Array(len);
    for (let i = 0; i < len; i++) {
      bytes[i] = binary.charCodeAt(i);
    }
    return bytes.buffer;
  } catch (e) {
    console.error("❌ base64ToArrayBuffer hatası:", e);
    return null;
  }
}
