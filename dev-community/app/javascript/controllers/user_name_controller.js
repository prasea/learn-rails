import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="user-name"
export default class extends Controller {
  static targets = ["fullName"]
  connect() {
    console.log("user-name controller connected")
  }
  alertName() {
    const nameElement = this.fullNameTarget;
    alert(`The developer name is ${nameElement.textContent}`)
  }
}
