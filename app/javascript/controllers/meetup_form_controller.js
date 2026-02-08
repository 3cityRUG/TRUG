import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "eventType",
    "formalFields",
    "numberField",
    "numberRequiredIndicator"
  ];

  connect() {
    this.toggle();
  }

  toggle() {
    const isFormal = this.eventTypeTarget.value === "formal";

    if (isFormal) {
      this.formalFieldsTarget.style.display = "block";
      this.numberFieldTarget.required = true;
      this.numberFieldTarget.disabled = false;
      this.numberRequiredIndicatorTarget.style.display = "inline";
      return;
    }

    this.formalFieldsTarget.style.display = "none";
    this.numberFieldTarget.required = false;
    this.numberFieldTarget.disabled = true;
    this.numberFieldTarget.value = "";
    this.numberRequiredIndicatorTarget.style.display = "none";
  }
}
