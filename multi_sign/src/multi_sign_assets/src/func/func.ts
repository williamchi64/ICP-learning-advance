const try_catch = async function <F extends Function> (async: F, ...params : Array<any>) {

	try {
		return (params.length === 0) ? (await async()) : (await async(params));
	} catch (error) {
		console.error(error);
		return error;
	};

};
export default {
    try_catch
};