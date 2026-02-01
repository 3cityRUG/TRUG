import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  play(event) {
    event.preventDefault();

    const button = event.currentTarget;
    const container = this.element;
    const { videoId, videoProvider } = container.dataset;

    if (!videoId || !videoProvider) return;

    const iframe = this.createIframe(videoId, videoProvider);
    container.replaceChild(iframe, button);
  }

  getVideoUrl(videoId, provider) {
    if (provider === "youtube") {
      return `https://www.youtube.com/embed/${videoId}/?autoplay=1&rel=0`;
    } else if (provider === "vimeo") {
      return `https://player.vimeo.com/video/${videoId}?autoplay=true`;
    }
    return "";
  }

  createIframe(videoId, provider) {
    const iframe = document.createElement("iframe");
    iframe.src = this.getVideoUrl(videoId, provider);
    iframe.width = "560";
    iframe.height = "315";
    iframe.allow =
      "accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture";
    iframe.allowFullscreen = true;
    iframe.className = "video-iframe";
    iframe.loading = "lazy";
    return iframe;
  }
}
