DEFAULT_BLOCKED = {
    "youtube",
    "tiktok",
    "netflix",
}

DEFAULT_ALLOWED = {
    "google",
    "github",
    "reddit",
    "facebook",
    "instagram",
}


class RuleManager:

    def __init__(self, blocked=None, allowed=None):
        self.blocked = set(blocked or DEFAULT_BLOCKED)
        self.allowed = set(allowed or DEFAULT_ALLOWED)

    def is_blocked(self, application):
        if not application:
            return False

        return application.lower() in self.blocked

    def is_allowed(self, application):
        if not application:
            return False

        return application.lower() in self.allowed

    def decide(self, application):
        if self.is_blocked(application):
            return "BLOCK"

        if self.is_allowed(application):
            return "ALLOW"

        return "UNKNOWN"
