'use strict';

(function iifeMenu(document, window, undefined) {
	var menuBtn = document.querySelector('.menu__btn');
	var	menu = document.querySelector('.menu__list');

	function toggleMenu() {
		menu.classList.toggle('menu__list--active');
		menu.classList.toggle('menu__list--transition');
		this.classList.toggle('menu__btn--active');
		this.setAttribute(
			'aria-expanded',
			this.getAttribute('aria-expanded') === 'true' ? 'false' : 'true'
		);
	}

	function removeMenuTransition() {
		this.classList.remove('menu__list--transition');
	}

	function handleSubmenuClick(e) {
		// if a parent item (has children) was clicked on mobile, toggle open state
		var link = e.target.closest('.menu__link');
		if (!link) return;
		var item = link.closest('.menu__item--has-children');
		if (!item) return;
		if (window.innerWidth < 767) {
			e.preventDefault();
			item.classList.toggle('menu__item--open');
		}
	}

	if (menuBtn && menu) {
		menuBtn.addEventListener('click', toggleMenu, false);
		menu.addEventListener('transitionend', removeMenuTransition, false);
		menu.addEventListener('click', handleSubmenuClick, false);
	}
}(document, window));
