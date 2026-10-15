<script setup>
import { computed, onMounted, onUnmounted, ref } from 'vue';
import { ChevronLeft, ChevronRight, Send } from '@lucide/vue';
import AmbientParticles from './components/AmbientParticles.vue';
import { saveSubmission } from './submissions.js';

const puzzleStartedAt = Date.parse('2026-10-12T21:02:00-06:00');
const currentTime = ref(Date.now());
const elapsedDays = computed(() =>
	Math.max(0, Math.floor((currentTime.value - puzzleStartedAt) / 86400000)),
);
let dayCountInterval;

onMounted(() => {
	currentTime.value = Date.now();
	dayCountInterval = window.setInterval(() => {
		currentTime.value = Date.now();
	}, 1000);
});

onUnmounted(() => {
	window.clearInterval(dayCountInterval);
});

const copied = ref(false);
const copyError = ref(false);
const answer = ref('');
const answerResult = ref('');
const isSubmitting = ref(false);
const submissionError = ref('');
const answerFeedback = computed(() => {
	if (isSubmitting.value) return 'Submitting...';
	if (submissionError.value) return submissionError.value;
	if (answerResult.value === 'invalid') return 'Enter exactly 8 letters.';
	if (answerResult.value === 'wrong') return 'Incorrect answer.';
	if (answerResult.value === 'correct') return 'Correct answer!';
	return '';
});

async function submitAnswer() {
	if (isSubmitting.value) return;
	submissionError.value = '';
	const submittedAnswer = answer.value;
	if (!/^[A-Za-z]{8}$/.test(submittedAnswer)) {
		answerResult.value = 'invalid';
		return;
	}
	isSubmitting.value = true;
	answerResult.value = '';
	try {
		await saveSubmission(submittedAnswer);
		answerResult.value =
			submittedAnswer.toLowerCase() === 'ucheated' ? 'correct' : 'wrong';
		if (answerResult.value === 'correct') {
			window.alert('this is not the correct answer. Try again.');
		}
	} catch {
		submissionError.value = 'Could not save your answer. Please try again.';
	} finally {
		isSubmitting.value = false;
	}
}

const currentHint = ref(0);
const hints = [
	"You won't guess the word, it will be obvious when it's found.",
	'The word is not on this page, and not in a book. But locked in a crate somewhere in the woods.',
	'TEN',
];

function changeHint(direction) {
	currentHint.value =
		(currentHint.value + direction + hints.length) % hints.length;
}

const clues = [
	'llonK leunamE yb ,”tserevE nwoD gnillaF“',
	'siloS ybloC yb ,"yrutneC htneeteniN eht fo trA"',
	'ynneD eirraK yb ,"egdirbseroG"',
	'ssaH ttaM egduJ yb ,"thgiR tsriF ,tnemdnemA dnoceS"',
	'senreV seluJ yb ,"saeS eht rednU seugaeL 000,02"',
	'tnuolB sucraM yb ,"efiL lluF ,kcabretrauQ"',
	'norreH odnanreF lareneG yb ,"ssoL thgieW fo sterceS deifissalC ehT"',
	'llehcS kciwdahC yb ,"spetstooF eht dna niaR ehT"',
	'edaDcM .M repiP yb ,"yrotcaF niarB eht ta elbuorT"',
	'sixefuoT .Z ettenyL yb ,"kseD eht dniheB"',
];

async function copyLink() {
	copied.value = false;
	copyError.value = false;

	try {
		await navigator.clipboard.writeText(window.location.href);
		copied.value = true;
		window.setTimeout(() => {
			copied.value = false;
		}, 2200);
	} catch {
		copyError.value = true;
	}
}
</script>

<template>
	<AmbientParticles />
	<div class="page-shell">
		<main>
			<section
				id="puzzle"
				class="puzzle-layout"
				aria-labelledby="puzzle-heading"
			>
				<aside
					class="status-card status-card-main"
					aria-label="Puzzle status"
				>
					<div class="status-top">
						<span
							class="status-indicator"
							aria-hidden="true"
						></span>
						<span>STATUS</span>
					</div>
					<p class="status-value">
						UNSOLVED
						<span
							class="puzzle-day-count"
							title="Started October 12, 2026 at 9:02 PM CST (UTC-6)"
						>
							{{ elapsedDays }}
							{{ elapsedDays === 1 ? 'DAY' : 'DAYS' }} RUNNING
						</span>
					</p>
					<div class="status-rule"></div>
					<div class="reward">
						<span class="reward-label">BOUNTY</span>
						<span class="reward-amount"
							>100K <span>SCRAP</span></span
						>
					</div>
					<p class="status-note">
						GIVING AWAY 100k SCRAP TOO WHOEVER SOLVES THIS PUZZLE.
						LASTS UNTIL THE CORRECT ANSWER IS TURNED IN.
					</p>
				</aside>

				<div class="puzzle-main">
					<div class="puzzle-card">
						<div class="puzzle-screen">
							<div class="screen-content">
								<p class="number-sequence">
									T W O F O U R S I X
								</p>
								<ul class="clue-list">
									<li v-for="clue in clues" :key="clue">
										<span class="clue-text">{{
											clue
										}}</span>
									</li>
								</ul>
							</div>
						</div>
					</div>
				</div>

				<aside class="puzzle-sidebar">
					<section
						class="sidebar-block hint-block"
						aria-labelledby="hint-heading"
					>
						<h3 id="hint-heading">HINT</h3>
						<div
							class="hint-slides"
							aria-live="polite"
							aria-atomic="true"
						>
							<p
								v-for="(hint, index) in hints"
								:key="hint"
								class="hint-quote"
								:class="{
									'hint-active': index === currentHint,
									'hint-vertical': index === 2,
								}"
								:aria-hidden="index !== currentHint"
							>
								{{
									index === 2 ?
										hint.split('').join('\n')
									:	hint
								}}
							</p>
						</div>
						<div class="hint-controls">
							<button
								type="button"
								class="hint-arrow"
								aria-label="Previous hint"
								title="Previous hint"
								@click="changeHint(-1)"
							>
								<ChevronLeft :size="20" aria-hidden="true" />
							</button>
							<span class="hint-counter"
								>{{ currentHint + 1 }} /
								{{ hints.length }}</span
							>
							<button
								type="button"
								class="hint-arrow"
								aria-label="Next hint"
								title="Next hint"
								@click="changeHint(1)"
							>
								<ChevronRight :size="20" aria-hidden="true" />
							</button>
						</div>
					</section>

					<section
						class="sidebar-block details-block"
						aria-labelledby="details-heading"
					>
						<h3 id="details-heading">INFO</h3>
						<dl class="details-list">
							<div><dt>THE ANSWER IS AN 8-LETTER WORD.</dt></div>
							<div>
								<dt>
									THE WORD IS NOT RELATED TO PZ BUT THE PUZZLE
									IS.
								</dt>
							</div>
							<div>
								<dt>
									(YOU DO NOT NEED TO BE AN EXPERIENCED
									ZOMBOID PLAYER TO FIND THE ANSWER).
								</dt>
							</div>
						</dl>
					</section>

					<section
						class="submit-card"
						aria-labelledby="submit-heading"
					>
						<p class="eyebrow">ANSWER FOUND?</p>
						<h3 id="submit-heading">SUBMIT ANSWER</h3>
						<form
							class="answer-form"
							:aria-busy="isSubmitting"
							novalidate
							@submit.prevent="submitAnswer"
						>
							<div class="answer-controls">
								<input
									id="puzzle-answer"
									v-model="answer"
									class="answer-input"
									:class="{
										'answer-wrong':
											answerResult === 'wrong' ||
											answerResult === 'invalid',
										'answer-correct':
											answerResult === 'correct',
									}"
									type="text"
									aria-label="8-letter answer"
									aria-describedby="answer-feedback"
									:aria-invalid="
										answerResult === 'wrong' ||
										answerResult === 'invalid'
									"
									placeholder="Your answer"
									minlength="8"
									maxlength="8"
									pattern="[A-Za-z]{8}"
									required
									autocomplete="off"
									autocapitalize="off"
									:spellcheck="false"
									:disabled="isSubmitting"
									@input="
										answerResult = '';
										submissionError = '';
									"
								/>
								<button
									class="answer-submit"
									type="submit"
									aria-label="Submit answer"
									title="Submit answer"
									:disabled="isSubmitting"
								>
									<Send :size="18" aria-hidden="true" />
								</button>
							</div>
							<p
								id="answer-feedback"
								class="answer-feedback"
								role="status"
							>
								{{ answerFeedback }}
							</p>
						</form>
						<p>
							DM BLISS ON DISCORD THE CORRECT ANSWER WHEN FOUND.
						</p>
					</section>
				</aside>
			</section>

			<section class="closing-note">
				<span class="closing-star" aria-hidden="true">✳</span>
				<p>STAY SHARP, SURVIVOR. <span>THE SCRAP IS YOURS.</span></p>
			</section>
		</main>

		<footer class="site-footer">
			<span>PROJECT ZOMBOID // COMMUNITY PUZZLE</span>
			<span>100K SCRAP BOUNTY ACTIVE</span>
		</footer>
	</div>
</template>
