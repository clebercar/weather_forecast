import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "spinner", "buttonText"]

  submit() {
    this.buttonTarget.disabled = true
    this.spinnerTarget.classList.remove("hidden")
    this.buttonTextTarget.textContent = "Searching..."
  }
}
