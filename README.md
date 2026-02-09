# 🛰️ Small Object Detection Web App
### Flutter Web + YOLOv8 (Baseline & Enhanced)

A **Flutter Web application** for detecting **small objects in images and videos** using:

- 🔹 Baseline YOLOv8
- 🔹 Enhanced YOLOv8 

This project focuses on improving **small-object detection accuracy** by enhancing the YOLOv8 architecture.

✅ Frontend (UI + Workflow) Completed  
🚧 Backend (Model Inference API) In Progress  

---

## 📌 Project Motivation

Small objects are difficult to detect because:

- Very few pixels
- Scale variation
- Background noise
- Feature loss in deep layers

Traditional YOLO models often miss these objects.

To overcome this, we implemented:

👉 Enhanced Neck Architecture  
👉 Better Feature Fusion  
👉 Multi-scale Detection Improvements  

---

## 🚀 Features

✅ Flutter Web responsive interface  
✅ Image detection screen  
✅ Video detection screen  
✅ Baseline vs Enhanced mode selection  
✅ Detection results preview  
✅ Modular screen-based routing  
✅ Clean and minimal UI  

---

## 🧠 Application Workflow

```

Intro Screen
↓
Mode Selection (Image / Video)
↓
Upload Media
↓
YOLOv8 Inference (Backend - Planned)
↓
Detection Results with Bounding Boxes

```

---

## 🛠️ Tech Stack

| Layer | Technology |
|-----------|-------------|
| Frontend | Flutter Web |
| Model | YOLOv8 |
| Enhancements | AGBiFPN + SOCS |
| Backend (Planned) | FastAPI / Flask |
| Image Processing | OpenCV |

---

## 📂 Project Structure

```

lib/
┣ screens/
┃ ┣ intro_screen.dart
┃ ┣ mode_selection_screen.dart
┃ ┣ image_detection_screen.dart
┃ ┣ video_detection_screen.dart
┃ ┗ result_screen.dart
┣ router.dart
┗ main.dart

assets/
┗ images / screenshots

android/
test/
README.md
pubspec.yaml

````

---

## 📸 Screenshots

> Add your images inside: `assets/screenshots/`

### Home / Intro
<img src="assets/screenshots/intro.png" width="45%"/>

### Mode Selection
<img src="assets/screenshots/mode.png" width="45%"/>

### Image Detection
<img src="assets/screenshots/image.png" width="45%"/>

### Results Screen
<img src="assets/screenshots/result.png" width="45%"/>

---

## 🔬 Detection Models

### 🔹 Baseline
Standard YOLOv8 model

### 🔹 Enhanced (Our Work)
- AGBiFPN Neck
- SOCS Feature Fusion
- Improved small-object representation
- Better multi-scale learning

These improvements help detect **tiny and distant objects more accurately**.

---

## ⚙️ Installation

### 1️⃣ Clone Repository

```bash
git clone https://github.com/your-username/your-repo-name.git
cd your-repo-name
````

### 2️⃣ Install Packages

```bash
flutter pub get
```

### 3️⃣ Run Web App

```bash
flutter run -d chrome
```

---

## 📈 Current Status

| Module             | Status     |
| ------------------ | ---------- |
| UI/Frontend        | ✅ Done     |
| Navigation/Routing | ✅ Done     |
| Image Upload       | ✅ Done     |
| Video Upload       | ✅ Done     |
| Detection UI       | ✅ Done     |
| Backend API        | 🚧 Pending |
| Model Deployment   | 🚧 Pending |

---

## 🎯 Future Work

* Backend inference API integration
* Real-time detection
* Video streaming support
* Performance metrics dashboard
* Cloud deployment
* Authentication system

---

## 👩‍💻 Team Contributions

* Flutter UI Development
* Screen-based routing
* YOLOv8 baseline testing
* Enhanced neck architecture design
* Dataset preparation & evaluation

---

## 📜 License

For academic and research use only.

---

## ⭐ Acknowledgement

Built using Flutter and YOLOv8 with custom enhancements for small object detection.
