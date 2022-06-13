import { html, render } from "lit-html";

const content = () => html
`<div id="postProposal">
    <label for="fname">First name:</label><br>
    <input type="text" id="fname" name="fname"><br>
    <label for="lname">Last name:</label><br>
    <input type="text" id="lname" name="lname">
</div>`;

export const renderPostProposal = () => {

    render(content(), document.getElementById("blkPostProposal") as HTMLElement);

};