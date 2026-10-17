const pay = () => {
  if (typeof gon === "undefined" || !gon.public_key) return;

  const form = document.getElementById("charge-form");
  if (!form || form.dataset.payjpBound === "true") return;
  form.dataset.payjpBound = "true";

  const payjp = Payjp(gon.public_key);
  const elements = payjp.elements();
  const numberElement = elements.create("cardNumber");
  const expiryElement = elements.create("cardExpiry");
  const cvcElement = elements.create("cardCvc");

  numberElement.mount("#number-form");
  expiryElement.mount("#expiry-form");
  cvcElement.mount("#cvc-form");

  form.addEventListener("submit", (event) => {
    event.preventDefault();
    payjp.createToken(numberElement).then((response) => {
      if (response.error) {
        window.alert("カード情報を確認してください");
        return;
      }

      const tokenInput = document.createElement("input");
      tokenInput.type = "hidden";
      tokenInput.name = "token";
      tokenInput.value = response.id;
      form.appendChild(tokenInput);
      form.submit();
    });
  });
};

document.addEventListener("turbo:load", pay);
document.addEventListener("turbo:render", pay);
