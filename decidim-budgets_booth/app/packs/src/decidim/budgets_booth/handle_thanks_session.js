$(() => {
  const $modal = $("#thanks-message");
  const $buttonConfirm = $("[data-confirm-ok]", $modal);
  const $buttonCancel = $("[data-confirm-cancel]", $modal);
  const $buttonClose = $("[data-dialog-closable]", $modal);
  console.log(`bool: ${Boolean($modal)}`)
  console.log(`session: ${$modal.attr("data-session") === "true"}`)
  if (Boolean($modal) && $modal.attr("data-session") === "true") {
    $modal.attr("aria-hidden", false)
  }
  $buttonConfirm.on("click", (ev)=> {
    $modal.attr("aria-hidden", true)
  })
  $buttonCancel.on("click", (ev)=> {
    $modal.attr("aria-hidden", true)
  })
  $buttonClose.on("click", (ev)=> {
    $modal.attr("aria-hidden", true)
  })
});

