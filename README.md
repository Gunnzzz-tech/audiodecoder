<img width="1193" height="766" alt="Screenshot 2025-08-25 at 11 18 56 PM" src="https://github.com/user-attachments/assets/235ed7c5-ebff-4af7-bcec-3acdf9c6ea78" /># 🎶 AudioDecoder

A Flutter project that decodes a **hidden message** embedded inside an audio file (`hidden_message.wav`) using **frequency analysis**.  

Each character in the message is represented by a unique frequency tone. The app uses **FFT-based signal processing** to analyze the audio file, detect the dominant frequencies, and map them back to characters using a predefined frequency dictionary.

---

## 🔑 Problem Statement
You are given:
1. An audio file: `hidden_message.wav`  
2. A frequency mapping dictionary (see below)  

Inside the audio file, a **secret text message** has been encoded. Each character is represented by a unique frequency tone.

👉 Each tone lasts ~300ms, with a short silence (~100ms) between letters.

Your task is to **decode the hidden message** and display it inside the Flutter app.

---

<img width="1197" height="765" alt="Screenshot 2025-08-25 at 11 19 48 PM" src="https://github.com/user-attachments/assets/a5d07c4c-42e6-4848-89fb-7a0d21de42b5" />
<img width="1193" height="766" alt="Screenshot 2025-08-25 at 11 18 56 PM" src="https://github.com/user-attachments/assets/b89b870d-e5b6-4d62-9b02-17c758e4d78f" />


## 📝 Frequency Mapping Dictionary

```dart
{
  "A": 440,
  "B": 350,
  "C": 260,
  "D": 474,
  "E": 492,
  "F": 401,
  "G": 584,
  "H": 553,
  "I": 582,
  "J": 525,
  "K": 501,
  "L": 532,
  "M": 594,
  "N": 599,
  "O": 528,
  "P": 539,
  "Q": 675,
  "R": 683,
  "S": 698,
  "T": 631,
  "U": 628,
  "V": 611,
  "W": 622,
  "X": 677,
  "Y": 688,
  "Z": 693,
  " ": 418
}
