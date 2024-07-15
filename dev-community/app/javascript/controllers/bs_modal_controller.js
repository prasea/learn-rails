import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="modal"
export default class extends Controller {
  connect() {
    // Ensure the Bootstrap modal is initialized
    this.modal = new window.bootstrap.Modal(this.element, {
      keyboard: false
    })
    this.modal.show()
  }

  disconnect() {
    // Ensure the Bootstrap modal is hidden
    if (this.modal) {
      this.modal.hide()
    }
  }

  submitEnd(e) {
    console.log("The submit end is called")
    if (this.modal) {
      this.modal.hide()
    }
  }
}
