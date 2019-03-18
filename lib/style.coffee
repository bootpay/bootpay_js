style = document.createElement('style');
style.innerHTML = """
.bootpay-open {
  position: fixed !important;
  left: 0;
  right: 0;
  bottom: 0;
  top: 0;
  height: 100vh !important;
  overflow: hidden !important;
}

@media (min-width: 500px) {
  .bootpay-open {
    position: relative;
  }
}

@-webkit-keyframes sk-bouncedelay {
    0%, 80%, 100% {
        -webkit-transform: scale(0);
    }
    40% {
        -webkit-transform: scale(1.0);
    }
}

@keyframes sk-bouncedelay {
    0%, 80%, 100% {
        -webkit-transform: scale(0);
        transform: scale(0);
    }
    40% {
        -webkit-transform: scale(1.0);
        transform: scale(1.0);
    }
}

.bootpay-modal-open {
    position: fixed;
    overflow: hidden;
}

.bootpay-window {
    display: block;
    position: absolute;
    left: 0;
    right: 0;
    top: 0;
    bottom: 0;
    background-color: rgba(0, 0, 0, 0.7);
    z-index: 30000;
    text-align: center;
    white-space: nowrap;
    -webkit-overflow-scrolling: touch;
    -webkit-transform: translate3d(0, 0, 0);
}

@media (min-width: 500px) {
  .bootpay-window {
      display: block;
      position: fixed;
      left: 0;
      right: 0;
      top: 0;
      bottom: 0;
      background-color: rgba(0, 0, 0, 0.7);
      z-index: 30000;
      text-align: center;
      white-space: nowrap;
      -webkit-overflow-scrolling: touch;
      -webkit-transform: translate3d(0, 0, 0);
  }
}

.bootpay-window.transparent-mode {
    background-color: transparent;
}

.bootpay-window .progress-message-window {
    display: none;
    position: absolute;
    left: 0;
    right: 0;
    top: 0;
    bottom: 0;
    z-index: 30000;
    text-align: center;
    white-space: nowrap;
    padding: 1em;
}

.bootpay-window .progress-message-window.over {
    z-index: 30002;
}

.bootpay-window .progress-message-window .progress-message {
    display: inline-block;
    text-align: center;
    max-width: 600px;
    border-radius: 3px;
    width: 100%;
    background-color: transparent;
    vertical-align: middle;
    margin-top: -35%;
}

.bootpay-window .progress-message-window .close-message-box {
    display: inline-block;
    text-align: center;
    max-width: 600px;
    border-radius: 3px;
    width: 100%;
    white-space: pre-line;
    vertical-align: middle;
}

.bootpay-window .progress-message-window .close-message-box .close-popup {
    padding: 1rem;
    background-color: #fff;
    color: #333;
    border-radius: 3px;
}

.bootpay-window .progress-message-window .close-message-box .close-popup h4.sub-title {
    font-size: 18px;
    padding: 0;
    margin: 0;
    font-weight: 400;
}

.bootpay-window .progress-message-window .close-message-box .close-popup button.close-payment-window {
    margin-top: 2rem;
    display: block;
    width: 100%;
    padding: 1rem;
    border: 1px solid #5e72e4;
    border-radius: 2px;
    background-color: #5e72e4;
    border-radius: 5px;
    box-shadow: none;
    font-size: 16px;
    outline: none;
    color: #fff;
}

@media (min-width: 500px) {
    .bootpay-window .progress-message-window .progress-message {
        display: inline-block;
        width: 400px;
        vertical-align: middle;
        margin-top: 0;
    }
}

.bootpay-window .progress-message-window .progress-message span.text {
    font-weight: 400;
    color: #fff;
}

.bootpay-window .spinner .bounce {
    width: 10px;
    height: 10px;
    margin: 0 3px;
    background-color: #fff;
    border-radius: 100%;
    display: inline-block;
    -webkit-animation: sk-bouncedelay 1.4s infinite ease-in-out both;
    animation: sk-bouncedelay 1.4s infinite ease-in-out both;
}

.bootpay-window .spinner .bounce1 {
    -webkit-animation-delay: -0.32s;
    animation-delay: -0.32s;
}

.bootpay-window .spinner .bounce2 {
    -webkit-animation-delay: -0.16s;
    animation-delay: -0.16s;
}

.bootpay-window:before, .progress-message-window:before {
    display: inline-block;
    vertical-align: middle;
    height: 100%;
    content: ' ';
    background: transparent;
}

.bootpay-window iframe {
    position: relative;
    display: inline-block;
    width: 100%;
    height: 100%;
    border: none;
    outline: none;
    background-color: transparent;
    z-index: 30001;
}

@media (min-width: 500px) {
    .bootpay-window iframe {
        position: relative;
        display: inline-block;
        width: 400px;
        height: 100%;
        max-height: 760px;
        vertical-align: middle;
        background-color: transparent;
    }
}
"""
document.head.appendChild(style)