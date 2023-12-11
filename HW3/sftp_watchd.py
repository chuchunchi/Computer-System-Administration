# Python
import os
import shutil
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

class FileHandler(FileSystemEventHandler):
    def on_created(self, event):
        if not event.is_directory and event.src_path.endswith('.exe'):
            dest_dir = '/home/sftp/hidden/.exe/'
            os.makedirs(dest_dir, exist_ok=True)
            shutil.move(event.src_path, dest_dir)

def start_watch(path):
    event_handler = FileHandler()
    observer = Observer()
    observer.schedule(event_handler, path, recursive=True)
    observer.start()
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        observer.stop()
    observer.join()

if __name__ == "__main__":
    start_watch('/path/to/watch')