var archive = (function () {
    var playerTemplate = function (movieId, provider) {
        var player = document.createElement("iframe");
        player.src = movieUrl(movieId, provider);
        player.width = 460;
        player.height = 259;
        player.class = "compact-1/1";
        player.frameborder = 0;
        return player;
    };

    var movieUrl = function (movieId, provider) {
        if (provider == "youtube") {
            return "https://www.youtube.com/embed/" + movieId + "/?autoplay=1&rel=0";
        } else {
            return "https://player.vimeo.com/video/" + movieId + "?autoplay=true";
        }
    };

    var playVideo = function (event) {
        event.preventDefault();
        var $videoBox = this.closest(".video"),
            player = playerTemplate($videoBox.dataset.video_id, $videoBox.dataset.provider);
        $videoBox.appendChild(player);
        $videoBox.querySelector(".play, img").style.display = "none";
    };

    return {
        init: function () {
            var videos = document.querySelectorAll(".meetup img, .meetup .play");
            console.log(videos);
            for (var i = 0; i < videos.length; i++) {
                videos[i].addEventListener("click", playVideo);
            }
        },
    };
})();

document.addEventListener("DOMContentLoaded", function () {
    archive.init();
});
