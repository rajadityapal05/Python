APPLICATION_DOMAINS = {
    "youtube": [
        "youtube.com",
        "youtu.be",
        "googlevideo.com",
        "ytimg.com"
    ],

    "tiktok": [
        "tiktok.com",
        "tiktokcdn.com"
    ],

    "netflix": [
        "netflix.com",
        "nflxvideo.net",
        "nflximg.net"
    ],

    "google": [
        "google.com",
        "googleapis.com",
        "gstatic.com"
    ],

    "github": [
        "github.com",
        "githubusercontent.com"
    ],

    "reddit": [
        "reddit.com",
        "redd.it",
        "redditmedia.com"
    ],

    "facebook": [
        "facebook.com",
        "fbcdn.net",
        "fb.com"
    ],

    "instagram": [
        "instagram.com",
        "cdninstagram.com"
    ]
}


def domain_matches(domain, candidate):
    domain = domain.lower().rstrip(".")
    candidate = candidate.lower().rstrip(".")

    return (
        domain == candidate
        or domain.endswith("." + candidate)
    )


class ApplicationClassifier:

    @staticmethod
    def classify(domain):

        if not domain:
            return None

        for application, domains in APPLICATION_DOMAINS.items():

            for candidate in domains:

                if domain_matches(domain, candidate):
                    return application

        return "other"
