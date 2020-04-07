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
  -webkit-overflow-scrolling: auto !important;
}

@media (min-width: 500px) {
  .bootpay-open {
    position: relative;
    background-color: transparent;
  }
}

.bootpay-loading-spinner {
  display: inline-block;
  width: 42px;
  height: 42px;
  vertical-align: middle;
}

.bootpay-loading-spinner .bootpay-circle {
    width: 42px;
    height: 42px;
    animation: bootpay-loading-rotate 2s linear infinite;
    vertical-align: middle;
}

.bootpay-loading-spinner .bootpay-circle .bootpay-path {
    stroke-dasharray: 90, 150;
    stroke-dashoffset: 0;
    stroke-width: 2;
    stroke: #ffffff;
    stroke-linecap: round;
    animation: bootpay-loading-dash 1.5s ease-in-out infinite;
}

@keyframes bootpay-loading-rotate {
  100% {
    transform: rotate(360deg);
  }
}

@keyframes bootpay-loading-dash {
  0% {
    stroke-dasharray: 1, 200;
    stroke-dashoffset: 0;
  }
  50% {
    stroke-dasharray: 90, 150;
    stroke-dashoffset: -40px;
  }
  100% {
    stroke-dasharray: 90, 150;
    stroke-dashoffset: -120px;
  }
}

@-webkit-keyframes bootpay-loading-rotate {
  100% {
    transform: rotate(360deg);
  }
}

@-webkit-keyframes bootpay-loading-dash {
  0% {
    stroke-dasharray: 1, 200;
    stroke-dashoffset: 0;
  }
  50% {
    stroke-dasharray: 90, 150;
    stroke-dashoffset: -40px;
  }
  100% {
    stroke-dasharray: 90, 150;
    stroke-dashoffset: -120px;
  }
}

.bootpay-modal-open {
    position: fixed;
    overflow: hidden;
}

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
    max-width: 400px;
    border-radius: 3px;
    width: 100%;
    white-space: normal;
    vertical-align: middle;
}

.bootpay-window .progress-message-window .close-message-box .close-popup {
    padding: 14px;
    background-color: #fff;
    color: #333;
    border-radius: 3px;
}

.bootpay-window .progress-message-window .close-message-box .close-popup .close-popup-header {
  position: relative;
  text-align: right;
  padding: 14px;
}

.bootpay-window .progress-message-window .close-message-box .close-popup .close-popup-header button.close-btn {
    position: absolute;
    top: -10px;
    right: -4px;
    box-shadow: none;
    font-size: 24px;
    outline: none;
    border: 0;
    background: transparent;
    padding: 0;
    cursor: pointer;
}

.bootpay-window .progress-message-window .close-message-box .close-popup h4.sub-title {
    font-size: 18px;
    padding: 0;
    margin-top: 7px;
    font-weight: 400;
    margin-bottom: 18px;
    text-align: left;
}

.bootpay-window .progress-message-window .close-message-box .close-popup button.close-payment-window {
    display: block;
    width: 100%;
    padding: 14px;
    border: 1px solid #5e72e4;
    border-radius: 2px;
    background-color: #5e72e4;
    border-radius: 5px;
    box-shadow: none;
    font-size: 16px;
    outline: none;
    color: #fff;
    cursor: pointer;
}

.bootpay-window .progress-message-window .close-message-box .close-popup button.close-payment-window.naverpay-btn {
    border: 1px solid #0fbc60;
    background-color: #1ec800;
}


@media (min-width: 500px) {
    .bootpay-window .progress-message-window .progress-message {
        display: inline-block;
        width: 400px;
        vertical-align: middle;
        margin-top: 0;
    }
}

.bootpay-window .progress-message-window .progress-message .bootpay-text {
  margin-top: 1rem;
}

.bootpay-window .progress-message-window .progress-message .bootpay-popup-close {
  margin-top: 1rem;
}

.bootpay-window .progress-message-window .progress-message .bootpay-popup-close button {
  background: transparent;
  border: 0;
  outline: 0;
  text-decoration: underline;
  -webkit-appearance: none;
  cursor: pointer;
  font-size: 14px;
  color: #fff;
}

.bootpay-window .progress-message-window .progress-message .bootpay-text span.bootpay-inner-text {
    font-size: 14px;
    font-weight: 400;
    color: #ffffff;
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