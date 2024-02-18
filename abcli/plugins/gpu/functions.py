def get_status(verbose: bool = False):
    # https://pytorch.org/docs/stable/generated/torch.cuda.is_available.html
    try:
        import torch

        if torch.cuda.is_available():
            return True
    except Exception as e:
        if verbose:
            print(e)

    return False


# https://stackoverflow.com/questions/60987997/why-torch-cuda-is-available-returns-false-even-after-installing-pytorch-with
def validate():
    try:
        import torch

        print(torch.zeros(1).cuda())
        return True
    except Exception as e:
        print(e)
        return False
