import logging
from logging.handlers import RotatingFileHandler
from decouple import config

def get_logger(name="logger"):
    log_file = config("LOG_FILE", default="monitor.log")

    logger = logging.getLogger(name)
    logger.setLevel(logging.INFO)

    if not logger.handlers:
        handler = RotatingFileHandler(log_file, maxBytes=500_000, backupCount=0)
        formatter = logging.Formatter("%(asctime)s - %(levelname)s - %(message)s")
        handler.setFormatter(formatter)
        logger.addHandler(handler)

    return logger
