import { Application } from "@hotwired/stimulus"
import DatePickerController from "./date_picker_controller"

const application = Application.start()
application.register("date-picker", DatePickerController)
application.debug = false
window.Stimulus = application

export { application }
