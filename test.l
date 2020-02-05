(load "package://pr2eus/pr2-interface.l")
(pr2-init)

(defun gen-racket-coords (robot) ;; not only generate but also atach coords to pr2
  (let* ((l-list (send robot :link-list (send robot :rarm :end-coords :parent)))
        (link-rarm-end (elt l-list 7))
        (coords-racket (make-cascoords)))
    (send coords-racket :newcoords (send link-rarm-end :copy-worldcoords))
    (send coords-racket :translate #f(180 0 550) :local)
    (send link-rarm-end :assoc coords-racket)
    coords-racket))
(setq *coords-racket* (gen-racket-coords *pr2*))

(defun compute-inverse-jacobian (robot)
  (let* ((link (cdr (send robot :link-list (send (send robot :rarm :end-coords) :parent))))
         (j (send robot :calc-jacobian-from-link-list link
                  :move-target *coords-racket*
                  :rotation-axis nil
                  :translation-axis t))
         (j# (sr-inverse j)))
    j#))

(defun solve-ik-for-racket-surface (robot pos rpy)
  (send robot :rarm :inverse-kinematics
        (make-coords :pos pos :rpy rpy)
        :move-target *coords-racket*
        :rotation-axis t
        :use-torso nil))

(defun determine-joint-velocity (robot)
  (let* ((vec-surface (transform (send *coords-racket* :worldrot) #f(0 -1 0)))
        (joint-velocity-rarm (transform (compute-inverse-jacobian robot) vec-surface))
        (joint-velocity))
    (setq joint-velocity (scale 0.0 (send robot :angle-vector)))
    (dotimes (i 7)
      (setf (aref joint-velocity (+ i 8)) (aref joint-velocity-rarm i)))
    joint-velocity))

(defun transmit-av-sim-and-real (robot av &key (duration 3000))
  (print av)
  (send robot :angle-vector av)
  (send *ri* :angle-vector (send robot :angle-vector)))


(setq *home-ave* #f(300.745 60.6455 67.8894 71.2674 -118.622 20.1335 -29.9994 179.999 -37.337 -9.61532 -128.901 -49.2444 -184.925 -27.539 192.797 5.0947 -21.2682))

(setq *home-ave* #f(300.723 60.6977 66.9104 71.4052 -118.522 20.1368 -29.9994 179.999 -57.0218 1.49384 -177.136 -8.59437 -691.076 -46.5846 768.273 5.2567 -21.2682))

(transmit-av-sim-and-real *pr2* *home-av*)
(send *ri* :wait-interpolation)
(send *ri* :stop-grasp)
(speak-jp "つかみます")
(unix:sleep 2)
(send *ri* :start-grasp :rarm :gain 1)

(setq avel (determine-joint-velocity *pr2*))
(transmit-av-sim-and-real *pr2* *home-av*)
(dotimes (i 20)
  (transmit-av-sim-and-real *pr2* (v+ *home-av* (scale 100.0 avel)))
  (send *ri* :wait-interpolation)
  (transmit-av-sim-and-real *pr2* (v+ *home-av* (scale -700 avel)) :duration 1000)
  (unix:usleep 1500000)
  (send *ri* :stop-motion)
  )


#|

(setq *av* #f(297.571 3.44356 65.2285 119.65 -69.8154 -443.968 -5.72958 21.1499 -4.1331 11.8614 -181.308 -8.59437 0 -6.13266 -30 20 35))

(transmit-av-sim-and-real *pr2* *av*)
(send *ri* :wait-interpolation)
(send *ri* :stop-grasp)
(speak-jp "つかみます")
(unix:sleep 2)
(send *ri* :start-grasp :rarm :gain 1)

(defun test ()
  (setq *av-post* #f(297.571 3.44356 65.2285 119.65 -69.8154 -443.968 -5.72958 21.1499 -4.1331 11.8614 -0.0 -30 180 -6.13266 180 20 35))
  (send *ri* :angle-vector *av* 1000)
  (send *ri* :wait-interpolation)
  (speak-jp "2秒前")
  (unix:sleep 2)
  (send *ri* :angle-vector *av-post* 1000)
  (unix:usleep 500000)
  (send *ri* :stop-motion)
  (send *ri* :wait-interpolation))

(dotimes (i 30)
  (test))
|#



;("torso_lift_joint" "l_shoulder_pan_joint" "l_shoulder_lift_joint" "l_upper_arm_roll_joint" "l_elbow_flex_joint" "l_forearm_roll_joint" "l_wrist_flex_joint" "l_wrist_roll_joint" "r_shoulder_pan_joint" "r_shoulder_lift_joint" "r_upper_arm_roll_joint" "r_elbow_flex_joint" "r_forearm_roll_joint" "r_wrist_flex_joint" "r_wrist_roll_joint" "head_pan_joint" "head_tilt_joint")
