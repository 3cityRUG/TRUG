import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["menu"];
  static values = { expanded: Boolean };

  connect() {
    this.expandedValue = false;
  }

  toggle() {
    this.expandedValue = !this.expandedValue;
    this.updateMenuState();
  }

  updateMenuState() {
    this.menuTarget.classList.toggle("active", this.expandedValue);
    this.element.setAttribute("aria-expanded", this.expandedValue.toString());
  }

  closeOnClickOutside(event) {
    if (!this.element.contains(event.target) && this.expandedValue) {
      this.expandedValue = false;
      this.updateMenuState();
    }
  }
}
