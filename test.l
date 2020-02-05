(load "package://pr2eus/pr2-interface.l")
(pr2-init)

(defun gen-racket-coords (robot) ;; not only generate but also atach coords to pr2
  (let ((l-list (send robot :link-list (send robot :rarm :end-coords :parent)))
        (link-rarm-end (elt l-list 7))
        (coords-racket (make-cascoords)))
    (send coords-racket :newcoords (send link-rarm-end :copy-worldcoords))
    (send coords-racket :translate #f(180 0 300) :local)
    (send link-rarm-end :assoc coords-racket)
    (return-from coords)))
(setq *coords-racket* (gen-racket-coords *pr2*))

(defun transmit-av-sim-and-real (robot av &key (duration 3000))
  (print av)
  (send robot :angle-vector av)
  (send *ri* :angle-vector (send robot :angle-vector)))


(setq *av1* #f(297.632 3.31056 65.1655 119.76 -69.7656 -443.971 -5.72958 21.1549 -16.3079 -20.2598 26.9581 -34.065 -756.887 -42.8876 0 5.3947 -21.2682))

;11 13 
(send *ri* :stop-grasp)
(speak-jp "つかみます")
(unix:sleep 2)
(send *ri* :start-grasp :rarm :gain 1)


(defun test ()
  (setq *av* #f(297.571 3.44356 65.2285 119.65 -69.8154 -443.968 -5.72958 21.1499 -4.1331 11.8614 -181.308 -8.59437 0 -6.13266 -30 20 35))
  (setq *av-post* #f(297.571 3.44356 65.2285 119.65 -69.8154 -443.968 -5.72958 21.1499 -4.1331 11.8614 -0.0 -30 180 -6.13266 180 20 35))
  (send *ri* :angle-vector *av* 1000)
  (send *ri* :wait-interpolation)
  (speak-jp "2秒前")
  (unix:sleep 2)
  (send *ri* :angle-vector *av-post* 1000)
  (unix:usleep 1000000)
  (send *ri* :stop-motion)
  (send *ri* :wait-interpolation))

(dotimes (i 30)
  (test))



("torso_lift_joint" "l_shoulder_pan_joint" "l_shoulder_lift_joint" "l_upper_arm_roll_joint" "l_elbow_flex_joint" "l_forearm_roll_joint" "l_wrist_flex_joint" "l_wrist_roll_joint" "r_shoulder_pan_joint" "r_shoulder_lift_joint" "r_upper_arm_roll_joint" "r_elbow_flex_joint" "r_forearm_roll_joint" "r_wrist_flex_joint" "r_wrist_roll_joint" "head_pan_joint" "head_tilt_joint")
