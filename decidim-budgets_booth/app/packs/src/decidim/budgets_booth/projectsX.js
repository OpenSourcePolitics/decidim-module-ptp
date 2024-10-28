const initializeProjects = () => {
  const $projects = $("#projects, #project, .reveal.large");
  const $budgetSummaryTotal = $(".budget-summary__total");
  const $budgetExceedModal = $("#budget-excess");
  const $budgetSummary = $(".budget-summary__progressbox");
  const $voteButton = $(".budget-vote-button");
  const totalAllocation = parseInt($budgetSummaryTotal.attr("data-total-allocation"), 10);

  const cancelEvent = (event) => {
    $(event.currentTarget).removeClass("loading-spinner");
    event.stopPropagation();
    event.preventDefault();
  };

  $voteButton.on("click", "span", () => {
    $(".budget-list__action").click();
  });

  $projects.on("click", ".customized-budget", (event) => {
    const currentAllocation = parseInt($budgetSummary.attr("data-current-allocation"), 10);
    const $currentTarget = $(event.currentTarget);
    const projectAllocation = parseInt($currentTarget.attr("data-allocation"), 10);


    let $targetCategory = null;
    const $targetCategoryId = $currentTarget.parents(".budget-list__data").first().data("categoryId");
    if ($targetCategoryId !== undefined) {
        $targetCategory = $(`.vote_by_category[data-category-id=${$targetCategoryId}]`).first();
    }

    let quotaExceeded = ((currentAllocation + projectAllocation) > totalAllocation);
    let categoryQuotaExceeded = false;

    if ($targetCategory && $targetCategory.length > 0) {
        const currentCategoryAllocation = parseInt($targetCategory.attr("data-current-allocation"), 10);
        const totalCategoryAllocation = parseInt($targetCategory.attr("data-allocation"), 10);
        categoryQuotaExceeded = ((currentCategoryAllocation + projectAllocation) > totalCategoryAllocation || quotaExceeded);
    }
    
    if ($currentTarget.attr("disabled")) {
      cancelEvent(event);
    } else if (($currentTarget.attr("data-add") === "true") && categoryQuotaExceeded === true) {
      $(`#budget-excess-${$targetCategoryId}`).foundation("toggle");
      cancelEvent(event);
    } else if (($currentTarget.attr("data-add") === "true") && quotaExceeded === true) {
        $budgetExceedModal.foundation("toggle");
        cancelEvent(event);
    }
  });
};


export default initializeProjects;
