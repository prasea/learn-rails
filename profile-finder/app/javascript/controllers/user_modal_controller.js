import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="user-modal"
export default class extends Controller {
  connect() {
    console.log("I am connected !!!")
  }

  initialize() {
    this.element.setAttribute("data-action", "click->user-modal#showModal");
  }
  showModal(e) {
    e.preventDefault();
    this.url = this.element.getAttribute("href")
    // Making request to new action of users_controller as turbo-stream instead of as HTML
    fetch(this.url, {
      headers: {
        Accept: "text/vnd.turbo-stream.html"
      }
    })
      .then(response => response.text())
      .then(html => Turbo.renderStreamMessage(html))
  }
}
