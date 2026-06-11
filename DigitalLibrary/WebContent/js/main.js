/**
 * Digital Library — Main JavaScript
 * Progressive enhancement only — all core functionality works without JS.
 */

/* ── Submit button loading state ── */
document.addEventListener('DOMContentLoaded', function () {

    /* Add loading spinner to any form on submit */
    document.querySelectorAll('form').forEach(function (form) {
        form.addEventListener('submit', function (e) {
            var submitBtn = form.querySelector('button[type="submit"]');
            if (submitBtn) {
                var original = submitBtn.textContent;
                submitBtn.textContent = '⏳ Processing…';
                submitBtn.disabled = true;

                /* Re-enable after 6 s (in case of network error) */
                setTimeout(function () {
                    submitBtn.textContent = original;
                    submitBtn.disabled = false;
                }, 6000);
            }
        });
    });

    /* ── Auto-dismiss status alerts after 5 s ── */
    var alerts = document.querySelectorAll('.alert');
    alerts.forEach(function (alert) {
        setTimeout(function () {
            alert.style.transition = 'opacity .5s ease';
            alert.style.opacity = '0';
            setTimeout(function () { alert.remove(); }, 500);
        }, 5000);
    });

    /* ── Smooth entrance animation for cards ── */
    var cards = document.querySelectorAll(
        '.book-card, .action-card, .concept-card, .form-card, .info-panel'
    );
    if ('IntersectionObserver' in window) {
        var observer = new IntersectionObserver(function (entries) {
            entries.forEach(function (entry) {
                if (entry.isIntersecting) {
                    entry.target.style.animation = 'fadeInUp .4s ease forwards';
                    observer.unobserve(entry.target);
                }
            });
        }, { threshold: 0.1 });

        cards.forEach(function (card) {
            card.style.opacity = '0';
            observer.observe(card);
        });
    }

    /* Inject the keyframe if not already in stylesheet */
    if (!document.getElementById('dlAnimStyle')) {
        var style = document.createElement('style');
        style.id = 'dlAnimStyle';
        style.textContent = [
            '@keyframes fadeInUp {',
            '  from { opacity:0; transform:translateY(20px); }',
            '  to   { opacity:1; transform:translateY(0);    }',
            '}'
        ].join('\n');
        document.head.appendChild(style);
    }
});
