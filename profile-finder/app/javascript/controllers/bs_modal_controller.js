import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="bs-modal"
export default class extends Controller {
  connect() {
    this.modal = new bootstrap.Modal(this.element)
    this.modal.show()
  }

  //Once the bs modal server the purpose of view, edit or new. It needs to close and once it is closed, we need to disconnect as well 
  disconnect() {
    this.modal.hide();
  }

  //Hide bs modal once new or edit form is submitted successfully 
  submitEnd(event) {
    this.modal.hide();
  }
}
