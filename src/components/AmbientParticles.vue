<script setup>
import { onMounted, onUnmounted, ref } from 'vue'

const canvas = ref(null)

let animationFrame = 0
let context
let particles = []
let width = 0
let height = 0
let pointerX = -1000
let pointerY = -1000
let lastPointerX = pointerX
let lastPointerY = pointerY
let pointerDeltaX = 0
let pointerDeltaY = 0
let reducedMotion

function resizeCanvas() {
  const element = canvas.value
  if (!element || !context) return

  const pixelRatio = Math.min(window.devicePixelRatio || 1, 2)
  width = window.innerWidth
  height = window.innerHeight
  element.width = width * pixelRatio
  element.height = height * pixelRatio
  context.setTransform(pixelRatio, 0, 0, pixelRatio, 0, 0)

  const count = Math.min(130, Math.max(40, Math.round((width * height) / 9000)))
  particles = Array.from({ length: count }, () => ({
    x: Math.random() * width,
    y: Math.random() * height,
    vx: (Math.random() - 0.5) * 0.2,
    vy: (Math.random() - 0.5) * 0.2,
    radius: 0.7 + Math.random() * 1.3,
    alpha: 0.18 + Math.random() * 0.28,
    tint: Math.random() > 0.8 ? '242, 203, 103' : '119, 210, 223',
  }))

  if (reducedMotion?.matches) drawParticles(false)
}

function drawParticles(animate = true) {
  if (!context) return

  context.clearRect(0, 0, width, height)

  for (const particle of particles) {
    if (animate) {
      const dx = particle.x - pointerX
      const dy = particle.y - pointerY
      const distance = Math.hypot(dx, dy)
      const influence = Math.max(0, 1 - distance / 190)

      particle.vx += pointerDeltaX * influence * 0.012
      particle.vy += pointerDeltaY * influence * 0.012
      particle.vx *= 0.992
      particle.vy *= 0.992
      particle.x += particle.vx
      particle.y += particle.vy

      if (particle.x < 0) particle.x = width
      if (particle.x > width) particle.x = 0
      if (particle.y < 0) particle.y = height
      if (particle.y > height) particle.y = 0
    }

    context.beginPath()
    context.fillStyle = `rgba(${particle.tint}, ${particle.alpha})`
    context.arc(particle.x, particle.y, particle.radius, 0, Math.PI * 2)
    context.fill()
  }

  if (animate) {
    pointerDeltaX *= 0.82
    pointerDeltaY *= 0.82
    animationFrame = window.requestAnimationFrame(() => drawParticles())
  }
}

function handlePointerMove(event) {
  pointerX = event.clientX
  pointerY = event.clientY
  pointerDeltaX = Math.max(-35, Math.min(35, pointerX - lastPointerX))
  pointerDeltaY = Math.max(-35, Math.min(35, pointerY - lastPointerY))
  lastPointerX = pointerX
  lastPointerY = pointerY
}

function handleMotionPreferenceChange() {
  window.cancelAnimationFrame(animationFrame)
  drawParticles(!reducedMotion.matches)
}

onMounted(() => {
  context = canvas.value?.getContext('2d')
  if (!context) return

  reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)')
  resizeCanvas()
  window.addEventListener('resize', resizeCanvas)
  window.addEventListener('pointermove', handlePointerMove, { passive: true })
  reducedMotion.addEventListener('change', handleMotionPreferenceChange)
  if (!reducedMotion.matches) drawParticles()
})

onUnmounted(() => {
  window.cancelAnimationFrame(animationFrame)
  window.removeEventListener('resize', resizeCanvas)
  window.removeEventListener('pointermove', handlePointerMove)
  reducedMotion?.removeEventListener('change', handleMotionPreferenceChange)
})
</script>

<template>
  <canvas ref="canvas" class="ambient-particles" aria-hidden="true"></canvas>
</template>

<style scoped>
.ambient-particles {
  position: fixed;
  z-index: 0;
  inset: 0;
  width: 100%;
  height: 100%;
  pointer-events: none;
}
</style>
