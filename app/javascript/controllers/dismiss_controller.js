import { Controller } from "@hotwired/stimulus"

// Removes the element, e.g. a flash message's close button.
export default class extends Controller {
  dismiss() {
    this.element.remove()
  }
}
