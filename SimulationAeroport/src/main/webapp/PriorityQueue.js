  //PriorityQueue :
  class PriorityQueue {
    constructor() {
      this.queue = [];
    }

    enqueue(element, priority) {
      var queueElement = { element, priority };

      if (this.isEmpty()) {
        this.queue.push(queueElement);
      } else {
        var added = false;
        for (var i = 0; i < this.queue.length; i++) {
          if (queueElement.priority < this.queue[i].priority) {
            this.queue.splice(i, 0, queueElement);
            added = true;
            break;
          }
        }
        if (!added) {
          this.queue.push(queueElement);
        }
      }
    }

    dequeue() {
      if (this.isEmpty()) {
        return null;
      }
      return this.queue.shift();
    }

    isEmpty() {
      return this.queue.length === 0;
    }

    size() {
      return this.queue.length;
    }
  }

  // fin PriorityQueue
