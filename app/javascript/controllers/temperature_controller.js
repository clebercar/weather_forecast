import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["value", "unit"];
  static values = { active: { type: String, default: "F" } };

  toggle(event) {
    this.activeValue = event.params.unit;
  }

  activeValueChanged(unit) {
    this.valueTargets.forEach((element) => {
      const fahrenheitValue = parseFloat(element.dataset.f);

      element.textContent =
        unit === "F"
          ? Math.round(fahrenheitValue)
          : this.#convertsFahrenheitToCelsius(fahrenheitValue);
    });

    this.unitTargets.forEach((el) => {
      const isActive = el.dataset.unit === unit;
      el.classList.toggle("text-gray-900", isActive);
      el.classList.toggle("font-semibold", isActive);
      el.classList.toggle("text-gray-400", !isActive);
      el.classList.toggle("font-normal", !isActive);
    });
  }

  #convertsFahrenheitToCelsius(fahrenheitValue) {
    return Math.round(((fahrenheitValue - 32) * 5) / 9);
  }
}
