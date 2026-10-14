<script setup>
import { ref } from "vue";
import AmbientParticles from "./components/AmbientParticles.vue";

const copied = ref(false);
const copyError = ref(false);

const clues = [
	"llonK leunamE yb ,”tserevE nwoD gnillaF“",
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
				<aside class="status-card status-card-main" aria-label="Puzzle status">
					<div class="status-top">
						<span class="status-indicator" aria-hidden="true"></span>
						<span>STATUS</span>
					</div>
					<p class="status-value">UNSOLVED</p>
					<div class="status-rule"></div>
					<div class="reward">
						<span class="reward-label">BOUNTY</span>
						<span class="reward-amount">100K <span>SCRAP</span></span>
					</div>
					<p class="status-note">
						GIVING AWAY 100k SCRAP TOO WHOEVER SOLVES THIS PUZZLE. LASTS UNTIL
						THE CORRECT ANSWER IS TURNED IN.
					</p>
				</aside>

				<div class="puzzle-main">
					<div class="puzzle-card">
						<div class="puzzle-screen">
							<div class="screen-content">
								<p class="number-sequence">T W O F O U R S I X</p>
								<ul class="clue-list">
									<li v-for="clue in clues" :key="clue">
										<span class="clue-text">{{ clue }}</span>
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
						<p class="hint-quote">
							“You won't guess the word, it will be obvious when it's found.”
						</p>
					</section>

					<section
						class="sidebar-block details-block"
						aria-labelledby="details-heading"
					>
						<h3 id="details-heading">INFO</h3>
						<dl class="details-list">
							<div><dt>THE ANSWER IS AN 8-LETTER WORD.</dt></div>
							<div>
								<dt>THE WORD IS NOT RELATED TO PZ BUT THE PUZZLE IS.</dt>
							</div>
							<div>
								<dt>
									(YOU DO NOT NEED TO BE AN EXPERIENCED ZOMBOID PLAYER TO FIND
									THE ANSWER).
								</dt>
							</div>
						</dl>
					</section>

					<section class="submit-card" aria-labelledby="submit-heading">
						<p class="eyebrow">ANSWER FOUND?</p>
						<h3 id="submit-heading">REPORT TO BLISS</h3>
						<p>DM BLISS ON DISCORD THE CORRECT ANSWER WHEN FOUND.</p>
						<span class="submit-arrow" aria-hidden="true">▶</span>
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
