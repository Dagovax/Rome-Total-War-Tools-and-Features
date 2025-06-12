import whisper
import sys

# Check if a file was passed as an argument
if len(sys.argv) < 2:
    print("Usage: drag an audio file onto this script.")
    input("Press Enter to exit...")
    sys.exit(1)

file_path = sys.argv[1]  # The dropped file path
print(f"Detecting language for file: {file_path}")

model = whisper.load_model("turbo")

# load audio and pad/trim it to fit 30 seconds
audio = whisper.load_audio(file_path)
audio = whisper.pad_or_trim(audio)

# make log-Mel spectrogram and move to the same device as the model
mel = whisper.log_mel_spectrogram(audio, n_mels=model.dims.n_mels).to(model.device)

# decode the audio
_, probs = model.detect_language(mel)

# print language
print(f"Detected language: {max(probs, key=probs.get)}")

input("Press Enter to exit...")