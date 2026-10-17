import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "template"]

  add(event) {
    event.preventDefault()
    const html = this.templateTarget.innerHTML.replaceAll("NEW_RECORD", String(Date.now()))
    this.containerTarget.insertAdjacentHTML("beforeend", html)
  }
}
