import { Application } from "@hotwired/stimulus"
import { definitionsFromContext } from "@hotwired/stimulus-importmap-autoloader"

const application = Application.start()
application.load(definitionsFromContext("controllers"))

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }
