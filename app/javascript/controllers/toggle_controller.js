import { Controller } from "@hotwired/stimulus"

// Shows/hides the target, e.g. the navigation menu on small screens.
export default class extends Controller {
  static targets = ["content"]

  toggle() {
    this.contentTarget.classList.toggle("hidden")
  }
}
