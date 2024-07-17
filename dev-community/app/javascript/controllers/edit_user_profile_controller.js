import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="edit-user-profile"
export default class extends Controller {
  connect() {
    console.log("Edit user profile button is clicked !")
  }

  initialize() {
    this.element.setAttribute("data-action", "click->edit-user-profile#showModal")
  }

  showModal(event) {
    event.preventDefault();
    const url = this.element.getAttribute("href");

    fetch(url, {
      headers: {
        Accept: "text/vnd.turbo-stream.html"
      }
    })
      .then(response => {
        if (!response.ok) {
          throw new Error('Network response was not ok');
        }
        return response.text();
      })
      .then(html => Turbo.renderStreamMessage(html))
      .catch(error => console.error('There was a problem with the fetch operation:', error));
  }
}
