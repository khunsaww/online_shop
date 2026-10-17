import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["variant", "quantity"]

  connect() {
    this.change()
  }

  change() {
    const selected = this.variantTargets.find((element) => element.checked)
    if (!selected || !this.hasQuantityTarget) return

    const stock = Number(selected.dataset.stock)
    this.quantityTarget.disabled = stock < 1
    if (stock < 1) return

    this.quantityTarget.max = stock
    const current = Number(this.quantityTarget.value)
    if (current > stock) this.quantityTarget.value = stock
    if (!current || current < 1) this.quantityTarget.value = 1
  }
}
