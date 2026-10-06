package com.polymap.android.ui

import android.animation.ValueAnimator
import android.view.animation.PathInterpolator
import androidx.dynamicanimation.animation.FloatValueHolder
import androidx.dynamicanimation.animation.SpringAnimation
import androidx.dynamicanimation.animation.SpringForce
import kotlin.math.PI
import kotlin.math.pow

val easeInOut = PathInterpolator(0.42f, 0f, 0.58f, 1f)
val easeIn = PathInterpolator(0.42f, 0f, 1f, 1f)
val easeOut = PathInterpolator(0f, 0f, 0.58f, 1f)

/** Parameters of one UIView.animate(...) call. */
class AnimRun(
    val animated: Boolean,
    val durationMs: Long,
    val delayMs: Long = 0,
    /** UIKit usingSpringWithDamping (0..1) or null for a basic curve animation. */
    val springDamping: Float? = null,
    val interpolator: android.view.animation.Interpolator = easeInOut
) {
    companion object {
        val immediate = AnimRun(false, 0)
    }
}

/**
 * An animatable float property. Mirrors how UIKit captures property changes inside an animation
 * block: call [set] inside a block with the current [AnimRun] to animate towards the target.
 */
class AnimProp(initial: Float, private val apply: (Float) -> Unit) {
    var value: Float = initial
        private set
    var target: Float = initial
        private set
    private var spring: SpringAnimation? = null
    private var animator: ValueAnimator? = null

    init { apply(initial) }

    fun setImmediate(v: Float) {
        cancel()
        target = v
        value = v
        apply(v)
    }

    fun set(v: Float, run: AnimRun, onEnd: (() -> Unit)? = null) {
        if (!run.animated) {
            setImmediate(v); onEnd?.invoke(); return
        }
        if (target == v && (spring != null || animator != null)) return
        cancel()
        target = v
        if (value == v) { onEnd?.invoke(); return }
        val damping = run.springDamping
        if (damping != null) {
            val holder = FloatValueHolder(value)
            val response = (run.durationMs / 1000f) * 0.55f
            val stiffness = (2 * PI / response).pow(2).toFloat()
            val s = SpringAnimation(holder).apply {
                spring = SpringForce(v).setDampingRatio(damping.coerceIn(0.05f, 1f)).setStiffness(stiffness)
                addUpdateListener { _, value, _ -> this@AnimProp.value = value; apply(value) }
                addEndListener { _, _, _, _ -> spring = null; onEnd?.invoke() }
                minimumVisibleChange = 0.002f
            }
            spring = s
            if (run.delayMs > 0) {
                android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({ if (spring === s) s.start() }, run.delayMs)
            } else s.start()
        } else {
            val a = ValueAnimator.ofFloat(value, v).apply {
                duration = run.durationMs
                startDelay = run.delayMs
                interpolator = run.interpolator
                addUpdateListener { anim -> val f = anim.animatedValue as Float; value = f; apply(f) }
                addListener(object : android.animation.AnimatorListenerAdapter() {
                    override fun onAnimationEnd(animation: android.animation.Animator) { animator = null; onEnd?.invoke() }
                })
            }
            animator = a
            a.start()
        }
    }

    fun cancel() {
        spring?.cancel(); spring = null
        animator?.cancel(); animator = null
    }
}

/** Port of the iOS Animator: an ordered list of animation blocks that play together. */
class Animator {
    private class Step(val run: (Boolean) -> AnimRun, val block: (AnimRun) -> Unit, val completion: (() -> Unit)?)

    private val steps = mutableListOf<Step>()

    fun animate(durationMs: Long, delayMs: Long = 0, interpolator: android.view.animation.Interpolator = easeInOut,
                completion: (() -> Unit)? = null, block: (AnimRun) -> Unit): Animator {
        steps += Step({ animated -> AnimRun(animated, durationMs, delayMs, null, interpolator) }, block, completion)
        return this
    }

    fun spring(durationMs: Long, delayMs: Long = 0, damping: Float, completion: (() -> Unit)? = null, block: (AnimRun) -> Unit): Animator {
        steps += Step({ animated -> AnimRun(animated, durationMs, delayMs, damping) }, block, completion)
        return this
    }

    fun play(animated: Boolean = true) {
        for (s in steps) {
            val run = s.run(animated)
            s.block(run)
            val completion = s.completion
            if (completion != null) {
                if (run.animated) {
                    android.os.Handler(android.os.Looper.getMainLooper()).postDelayed(completion, run.durationMs + run.delayMs)
                } else completion()
            }
        }
    }
}

fun Float.dp(density: Float) = this * density
