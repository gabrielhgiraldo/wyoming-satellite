FROM python:3.11-slim-bookworm

ENV LANG C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install --yes --no-install-recommends avahi-utils

WORKDIR /app

COPY sounds/ ./sounds/
COPY script/setup ./script/
COPY setup.py requirements.txt requirements_vad.txt requirements_audio_enhancement.txt MANIFEST.in ./
COPY wyoming_satellite/ ./wyoming_satellite/

RUN script/setup

# Install VAD support (pysilero-vad) so --vad works for local end-of-speech
# detection. Uses the venv created by script/setup. 2026-07-02
RUN .venv/bin/pip install --no-cache-dir -r requirements_vad.txt

# Install audio-enhancement support (webrtc-noise-gain) so --mic-auto-gain and
# --mic-noise-suppression work. Needed because the AT2020 mic captures speech
# too quietly for HA's microVAD; adaptive auto-gain brings it up cleanly. 2026-07-03
RUN .venv/bin/pip install --no-cache-dir -r requirements_audio_enhancement.txt

COPY script/run ./script/
COPY docker/run ./

EXPOSE 10700

ENTRYPOINT ["/app/run"]
