let DragAndDropHook = {
  mounted() {
    this.dragCounter = 0;

    this.el.addEventListener("dragenter", (e) => {
      e.preventDefault();
      this.dragCounter++;

      if (this.dragCounter === 1) {
        this.pushEventTo(this.el, "file-dragging", { over: true });
      }
    });

    this.el.addEventListener("dragover", (e) => {
      e.preventDefault();
    });

    this.el.addEventListener("dragleave", (e) => {
      e.preventDefault();
      this.dragCounter--;
      if (this.dragCounter === 0) {
        this.pushEventTo(this.el, "file-dragging", { over: false });
      }
    });

    this.el.addEventListener("drop", (e) => {
      e.preventDefault();
      this.dragCounter = 0;
      this.pushEventTo(this.el, "file-dragging", { over: false });
    });
  },
};

export default DragAndDropHook;
