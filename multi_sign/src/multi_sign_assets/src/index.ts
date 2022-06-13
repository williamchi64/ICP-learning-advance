import { AuthClient } from "@dfinity/auth-client";
import { renderIndex } from "./views/index";
import { renderQuery } from "./views/query";
import { canisterId, createActor } from "../../declarations/multi_sign";
import { Actor, Identity } from "@dfinity/agent";
import { renderUpdate } from "./views/update";

export const init = async () => {
	const authClient = await AuthClient.create();
	if (await authClient.isAuthenticated()) {
		handleAuthenticated(authClient);
	};
	renderIndex();

	const loginButton = document.getElementById(
		"loginButton"
	) as HTMLButtonElement;

	const days = BigInt(1);
	const hours = BigInt(24);
	const nanoseconds = BigInt(3600000000000);

	loginButton.onclick = async () => {
		await authClient.login({
			onSuccess: async () => {
				handleAuthenticated(authClient);
			},
			identityProvider:
				process.env.DFX_NETWORK === "ic"
					? "https://identity.ic0.app/#authorize"
					: process.env.LOCAL_II_CANISTER,
			// Maximum authorization expiration is 8 days
			maxTimeToLive: days * hours * nanoseconds,
		});
	};
};

async function handleAuthenticated(authClient: AuthClient) {
	const identity = (await authClient.getIdentity()) as unknown as Identity;
	const multi_sign_actor = createActor(canisterId as string, {
		agentOptions: {
			identity,
		},
	});
	// Invalidate identity then render login when user goes idle
	authClient.idleManager?.registerCallback(() => {
		Actor.agentOf(multi_sign_actor)?.invalidateIdentity?.();
		renderIndex();
	});

	(document.getElementById("pageContent") as HTMLElement).remove();
	renderQuery(multi_sign_actor, authClient);
	renderUpdate(multi_sign_actor, authClient);

};

init();
