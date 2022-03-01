<asset:javascript src="swiper/swiper.min.js"></asset:javascript>
<g:set var="images" value="${hubConfig.templateConfiguration.banner.images}"></g:set>
<content tag="slider">
    <section class="hero-slider swiper-container">
        <div class="swiper-wrapper">
            <g:each var="image" in="${images}" status="index">
                <div class="swiper-slide" style="background-image: url(${image.url});">
                    <div class="slide-overlay">
                        <div class="container d-none d-md-block">
                            <h1>${hubConfig.title}</h1>
                            <g:if test="${image.caption}">
                                <p>${image.caption}</p>
                            </g:if>
                        </div>
                    </div>
                </div>
            </g:each>
        </div>
        <div class="swiper-pagination"></div>
    </section>
</content>

<script>
    $(document).ready(function () {
        /**
         * Hero Banner
         */
        $('.hero-slider').each((index, el) => {
            $(el).addClass('hero-slide-' + index);

            new Swiper('.hero-slide-' + index, {
                loop: true,
                slidesPerView: 1,
                spaceBetween: 0,
                speed: ${hubConfig?.templateConfiguration?.banner?.transitionSpeed ?: 1000},
                autoplay: {
                    delay: 5000,
                    disableOnInteraction: false
                },
                preventClicks: false,
                effect: 'fade',
                preloadImages: false,
                lazy: {
                    loadPrevNext: true,
                },
                navigation: false,
                pagination: {
                    el: '.swiper-pagination',
                    type: 'bullets',
                    clickable: true,
                },
            });
        });
    })
</script>