<template>

	<div class="">
		<navigation-component/>
		<div class="columns is-tablet">
			<sidebar-component class="column is-2 "/>
			<div class="column is-8">
				<section class="smallpad">
					<div class="form-wrapper" v-if="compState == 'form'">
						<h1 class="is-size-2"> Get in Touch <span class="has-text-info">:)</span></h1>
						<br/>
						<p>
						</p>
						<br/>

						<form class="">
							<div class="field">
								<label class="label">Email<sup class="has-text-danger">*</sup></label>
								<div class="control has-icons-left has-icons-right">
									<input class="input" type="email" placeholder="your@email.here" v-model="senderEmail">
									<span class="icon is-small is-left">
										<icon name="envelope-o"/>
									</span>
									<span class="icon is-small is-right has-text-warning" v-if="emailError">
										<icon name="warning"/>
									</span>
								</div>
								<p class="help is-danger" v-if="emailError">Need a valid email to reply to.</p>
							</div>

							<div class="field">
								<label class="label">Subject</label>
								<div class="control has-icons-left has-icons-right">
									<input class="input" type="text" placeholder="What's it about?" v-model="subject">
									<span class="icon is-small is-left">
										<icon name="question-circle-o"/>
									</span>
									<!-- <span class="icon is&#45;small is&#45;right"> -->
										<!--	 <icon name="warning"/> -->
										<!-- </span> -->
								</div>
								<p class="help is-info" v-if="subjectError">Autofill. Yay!</p>
							</div>

							<div class="field">
								<label class="label">Message</label>
								<div class="control">
									<textarea class="textarea" placeholder="Any other details?" v-model="message"></textarea>
								</div>
								<p class="help is-info" v-if="messageError">Autofill. Yay!</p>
							</div>

							<div class="field is-grouped">
								<p class="control">
									<a class="button is-light" @click="clearForm()">
										Clear
									</a>
								</p>
								<p class="control">
									<a class="button is-primary" @click="submitForm()">
										Submit
									</a>
								</p>
								<p class="help is-danger" v-if="!emailError && (subjectError || messageError)">Click again to confirm and send.</p>
							</div>
						</form>
					</div>

					<loading-component class="form-wrapper" v-if="compState == 'sending'" msg="Sending message.." style="overflow:hidden;"/>

					<div class="form-wrapper" v-if="compState == 'sent'">
						<h1 class="is-size-2">It's sent. <span class="has-text-success">:)</span></h1>
						<br/>
						<p>
						</p>
						<br/>

						<p>
							Your message is sent successfully.
							Expect a reply within 48hrs.
						</p>

						<p>
							However, if I've replied almost immediately,
							it could be the auto responder and I'm away.
						</p>
						<br/>

						<p>You can go back to the form if there's something more, <br/>or checkout some more of our images.</p>
						<br/>

						<div class="field is-grouped">
							<p class="control">
								<a class="button is-light" @click="clearForm()">
									Back
								</a>
							</p>
							<p class="control">
								<a class="button is-info" href="#/">
									Images
								</a>
							</p>
						</div>
					</div>

					<div class="form-wrapper" v-if="compState == 'failed'">
						<h1 class="is-size-2">Something went wrong. <span class="has-text-danger">:(</span></h1>
						<br/>
						<p>
						</p>
						<br/>

						<p>
							Looks like there was a problem sending your message.
						</p>

						<p>
							Most likely a network error, <br/>
							but it could very well be some <span class="has-text-warning">bug</span> that crept into the codes.
						</p>
						<br/>

						<p>You can go back to the form and try again, <br/>or checkout some more of our images.</p>
						<br/>

						<div class="field is-grouped">
							<p class="control">
								<a class="button is-light" @click="compState = 'form'">
									Back
								</a>
							</p>
							<p class="control">
								<a class="button is-info" href="#/">
									Images
								</a>
							</p>
						</div>
					</div>

				</section>
			</div>
		</div>
		<footer-component class="footer"/>
	</div>

</template>

<script>

	import NavigationComponent from '@/components/Navigation.vue';
	import SidebarComponent from '@/components/Sidebar.vue';
	import LoadingComponent from '@/components/Loader.vue';
	import FooterComponent from '@/components/Footer.vue';

	export default {
		name: 'AboutRoute',
		components : {
			NavigationComponent,
			SidebarComponent,
			LoadingComponent,
			FooterComponent
		},
		data () {
			return {
				senderEmail  : '',
				subject		 : '',
				message		 : '',
				compState	 : '',
				emailError	 : false,
				subjectError : false,
				messageError : false,
			}
		},
		methods : {
			emailTest (em) {
				let e = new RegExp(
					"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?"
				);
				return !em || !(e.test(em));
			},
			existsTest (s) {
				return !s;
			},
			clearForm () {
				this.compState = 'form';
				this.senderEmail  = '';
				this.subject	  = '';
				this.message	  = '';
				this.emailError   = false;
				this.subjectError = false;
				this.messageError = false;
			},
			submitForm () {
				this.emailError = this.emailTest(this.senderEmail);
				if(this.emailError) {
					return;
				}

				this.subjectError = this.existsTest(this.subject);
				if(this.subjectError) {
					this.subject = 'Hi from the Internet!';
				}

				this.messageError = this.existsTest(this.message);
				if(this.messageError) {
					this.message = 'This can be left empty.';
				}

				if(this.subjectError || this.messageError) return;

				this.compState = 'sending';

				this.$api.formspree.send(
					this.$store.state.email,
					this.senderEmail,
					this.subject,
					this.message
				).then(response => {
					if(response.data.ok) {
						this.compState = 'sent';
					} else {
						this.compState = 'failed';
					}
				}).catch((error) => {
					this.compState = 'failed';
					console.log( error )
				});
			}
		},
		mounted () {
			this.compState = 'form';
		}
	}

</script>

<style scoped>
	.smallpad { padding: 0 5vw; padding-top : 0.7em; }
	.form-wrapper { min-height: 70vh; }
</style>
