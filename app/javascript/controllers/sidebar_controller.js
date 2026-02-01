import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["sidebar", "overlay"];
  static values = { open: Boolean };

  connect() {
    this.openValue = false;
  }

  toggle() {
    this.openValue = !this.openValue;
    this.updateSidebarState();
  }

  open() {
    this.openValue = true;
    this.updateSidebarState();
  }

  close() {
    this.openValue = false;
    this.updateSidebarState();
  }

  updateSidebarState() {
    if (this.hasSidebarTarget) {
      this.sidebarTarget.classList.toggle("open", this.openValue);
    }
    if (this.hasOverlayTarget) {
      this.overlayTarget.classList.toggle("open", this.openValue);
    }
  }

  closeOnOverlayClick() {
    this.close();
  }

  closeOnEscape(event) {
    if (event.key === "Escape" && this.openValue) {
      this.close();
    }
  }
}
