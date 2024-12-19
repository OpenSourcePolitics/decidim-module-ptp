const initVoteCompleteElement = () => {
  const template = document.getElementById("vote-completed-snippet");
  if (!template) {
    return;
  }

  const wrapper = document.createElement("div");
  wrapper.innerHTML = template.innerText;

  const reveal = wrapper.querySelector("div");
  document.body.append(reveal);
}

initVoteCompleteElement();
$(() => {
  const $modal = $("#vote-completed");
  const $buttonConfirm = $("[data-confirm-ok]", $modal);
  const $buttonCancel = $("[data-confirm-cancel]", $modal);
  const $buttonClose = $("[data-dialog-closable]", $modal);

  $modal.attr("aria-hidden", false);

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
