$(() => {
  const $modal = $("#thanks-message");
  const $buttonConfirm = $("[data-confirm-ok]", $modal);
  const $buttonCancel = $("[data-confirm-cancel]", $modal);
  const $buttonClose = $("[data-dialog-closable]", $modal);

  if (Boolean($modal) && $modal.attr("data-session") === "true") {
    $modal.attr("aria-hidden", false)
  }
  $buttonConfirm.on("click", () => {
    $modal.attr("aria-hidden", true)
  })
  $buttonCancel.on("click", () => {
    $modal.attr("aria-hidden", true)
  })
  $buttonClose.on("click", () => {
    $modal.attr("aria-hidden", true)
  })
});

