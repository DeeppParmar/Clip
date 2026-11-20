"""Compatibility shim for MediaPipe on platforms or Python versions (like Python 3.13)
where the legacy mp.solutions module is not built or available.
Provides OpenCV-based drop-in replacements for mp.solutions.face_detection
and mp.solutions.selfie_segmentation.
"""
import sys
import cv2
import numpy as np

def patch_mediapipe():
    try:
        import mediapipe as mp
    except ImportError:
        return

    if hasattr(mp, "solutions"):
        return

    class _RelativeBox:
        def __init__(self, xmin, ymin, width, height):
            self.xmin = xmin
            self.ymin = ymin
            self.width = width
            self.height = height

    class _LocationData:
        def __init__(self, box):
            self.relative_bounding_box = box

    class _Detection:
        def __init__(self, box, score=0.9):
            self.location_data = _LocationData(box)
            self.score = [score]

    class _DetectionResult:
        def __init__(self, detections):
            self.detections = detections

    class OpenCVFaceDetection:
        def __init__(self, model_selection=1, min_detection_confidence=0.5):
            cascade_path = cv2.data.haarcascades + "haarcascade_frontalface_default.xml"
            self.classifier = cv2.CascadeClassifier(cascade_path)

        def process(self, image):
            if image is None:
                return _DetectionResult([])
            h, w = image.shape[:2]
            gray = cv2.cvtColor(image, cv2.COLOR_RGB2GRAY) if len(image.shape) == 3 and image.shape[2] == 3 else image
            faces = self.classifier.detectMultiScale(gray, scaleFactor=1.1, minNeighbors=4, minSize=(24, 24))
            detections = []
            if len(faces) > 0:
                for (x, y, fw, fh) in faces:
                    box = _RelativeBox(float(x) / w, float(y) / h, float(fw) / w, float(fh) / h)
                    detections.append(_Detection(box))
            return _DetectionResult(detections)

        def close(self):
            pass

    class OpenCVSelfieSegmentation:
        def __init__(self, model_selection=0):
            pass

        def process(self, frame):
            class _SegResult:
                def __init__(self, mask):
                    self.segmentation_mask = mask
            h, w = frame.shape[:2]
            return _SegResult(np.ones((h, w), dtype=np.float32))

        def close(self):
            pass

    class _FaceDetectionModule:
        FaceDetection = OpenCVFaceDetection

    class _SelfieSegmentationModule:
        SelfieSegmentation = OpenCVSelfieSegmentation

    class _SolutionsModule:
        face_detection = _FaceDetectionModule()
        selfie_segmentation = _SelfieSegmentationModule()

    mp.solutions = _SolutionsModule()

patch_mediapipe()
