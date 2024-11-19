$(() => {
  const $modal = $("#thanks-message");
  console.log(`bool: ${Boolean($modal)}`)
  console.log(`session: ${$modal.attr("data-session") === "true"}`)
  if (Boolean($modal) && $modal.attr("data-session") === "true") {
    $modal.foundation("open");
  }
});

