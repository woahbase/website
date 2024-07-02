const tabSync = () => {
  const tabs = document.querySelectorAll(".tabbed-set > input");
  for (const tab of tabs) {
    tab.addEventListener("click", () => {
      const current = document.querySelector(`label[for=${tab.id}]`);
      const pos = current.getBoundingClientRect().top;
      const labelContent = current.innerHTML;
      const labels = document.querySelectorAll('.tabbed-set > label, .tabbed-alternate > .tabbed-labels > label');
      for (const label of labels) {
        if (label.innerHTML === labelContent) {
          document.querySelector(`input[id=${label.getAttribute('for')}]`).checked = true;
        }
      }
      /* Preserve scroll position */
      const delta = (current.getBoundingClientRect().top) - pos;
      window.scrollBy(0, delta);
    })
  }
}

tabSync();

const redirectOldLink = () => {
  /* redirect old-style links (/#/images/alpine-activemq) to new pages (/images/alpine-activemq)*/
  if(location.hash.startsWith("#/images/")) {
    location.href = "/images/" + location.hash.replace("#/images/", "");
  }
}

const scrollPathIntoView = () => {
  if(location.pathname.startsWith("/images/")) {
    Array.from(document.querySelectorAll("a.md-nav__link.md-nav__link--active"))
      .filter(item=>location.href.startsWith(item.href))
      .forEach(item=>scrollTo(item));
  }
}

window.onload = () => {
  redirectOldLink();
  /* scrollPathIntoView();*/
};
