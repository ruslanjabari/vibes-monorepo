// I hate state but had to do it to em
class CircularArrayDeque {
  head: number;
  tail: number;
  arr: any[];
  size: number;
  constructor(capacity: any) {
    this.head = 0; // the first node in deque, not the first item in array
    this.tail = 0; // the last node in deque, not the first item in array
    this.arr = new Array(capacity);
    this.size = 0;
  }

  // Add item to the head of the deque
  addFirst(value: any) {
    // check if deque is full
    if (this.isFull()) {
      return null;
    }

    this.head = this.head - 1;
    if (this.head < 0) {
      this.head = this.arr.length - 1;
    }
    this.arr[this.head] = value;
    this.size += 1;
  }

  // Remove the first item from the deque and return its value
  removeFirst() {
    if (this.isEmpty()) {
        console.log("Circular Array Deque is empty when dequeue!");
        return null;
    }
    let value = this.arr[this.head];
    this.head = (this.head + 1) % this.arr.length;
    this.size -= 1;
    return value;
  }

  // Get the first item
  peekFirst() {
    if (this.isEmpty()) {
      console.log("Circular Array Deque is empty when peek!");
      return null;
    }
    return this.arr[this.head];
  }

  // Add item to the end of the deque
  addLast(value: any) {
    // check if deque is full
    if (this.isFull()) {
      return null;
    }
    this.tail = (this.head + this.size) % this.arr.length;
    this.arr[this.tail] = value;
    this.size += 1;
  }

  // Remove the last item from the deque and return its value
  removeLast() {
    if (this.isEmpty()) {
      console.log("Circular Array Deque is empty when dequeue!");
      return null;
    }

    let value = this.arr[this.tail];
    this.tail = this.tail - 1;
    if (this.tail < 0) {
      this.tail = this.arr.length - 1;
    }
    this.size -= 1;
    return value;
  }

  // Get the last item
  peekLast() {
    if (this.isEmpty()) {
      console.log("Circular Array Deque is empty when peek!");
      return null;
    }
    return this.arr[this.tail];
  }

  // Return whether the queue is full
  isFull() {
    return this.size == this.arr.length;
  }

  // Return whether the queue is empty
  isEmpty() {
    return this.size == 0;
  }
}

export default CircularArrayDeque;